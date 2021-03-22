using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace _3ta.business.Data
{
    public class TraceResult
    {
        public TraceResult()
        {
            Id = Guid.NewGuid();
            StartedAt = DateTime.Now;
            MachineName = System.Environment.MachineName;
            Identity = System.Environment.UserDomainName;
        }
        public TraceResult(Guid id) : this()
        {
            Id = id;
        }

        /// <summary>
        /// Defaults to <see cref="Guid.NewGuid"/>
        /// </summary>
        public Guid Id { get; set; }
        public string Name { get; set; }

        /// <summary>
        /// Defaults to <see cref="System.Environment.UserDomainName"/>
        /// </summary>
        public string Identity { get; set; }
        /// <summary>
        /// Defaults to <see cref="System.Environment.MachineName"/>
        /// </summary>
        public string MachineName { get; set; }
        public DateTime StartedAt { get; set; }
        /// <summary>
        /// Use the <see cref="Finish(string)"/> method set this.  Preferrably, call it when the "child" traces have been called.
        /// </summary>
        public DateTime FinishedAt { get; set; }
        public string Payload { get; set; }
        public void Finish(string payload)
        {
            Payload = payload;
            FinishedAt = DateTime.Now;
        }
        public TimeSpan Elapsed => FinishedAt - StartedAt;

    }
}

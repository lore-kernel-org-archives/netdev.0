From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Tue, 12 Feb 2013 09:28:53 +0530
Message-ID: <5119BDFD.1000909@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <510FBC01.2030405@linux.vnet.ibm.com> <87haloiwv0.fsf@rustcorp.com.au> <51134596.4080106@linux.vnet.ibm.com> <20130208154113.GV17833@n2100.arm.linux.org.uk> <51152B81.2050501@linux.vnet.ibm.com> <51153F72.1060005@linux.vnet.ibm.com> <CAKfTPtCe+cD7LLkb+D6pqG1SwG2V08ws=4XO3ttHEHV2qgmqPg@mail.gmail.com> <5118E2CD.90401@linux.vnet.ibm.com> <20130211190852.GA5695@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vincent Guittot <vincent.guittot@linaro.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	walken@google.com, mingo@kernel.org, linux-arch@vger.kernel.org,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>, rostedt@goodmis.org,
	rjw@sisk.pl, namhyung@kernel.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130211190852.GA5695@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/12/2013 12:38 AM, Paul E. McKenney wrote:
> On Mon, Feb 11, 2013 at 05:53:41PM +0530, Srivatsa S. Bhat wrote:
>> On 02/11/2013 05:28 PM, Vincent Guittot wrote:
>>> On 8 February 2013 19:09, Srivatsa S. Bhat
>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
> 
> [ . . . ]
> 
>>>> Adding Vincent to CC, who had previously evaluated the performance and
>>>> latency implications of CPU hotplug on ARM platforms, IIRC.
>>>>
>>>
>>> Hi Srivatsa,
>>>
>>> I can try to run some of our stress tests on your patches.
>>
>> Great!
>>
>>> Have you
>>> got a git tree that i can pull ?
>>>
>>
>> Unfortunately, no, none at the moment..  :-(
> 
> You do need to create an externally visible git tree.

Ok, I'll do that soon.

>  In the meantime,
> I have added your series at rcu/bhat.2013.01.21a on -rcu:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-rcu.git
> 
> This should appear soon on a kernel.org mirror near you.  ;-)
>

Thank you very much, Paul! :-)

Regards,
Srivatsa S. Bhat

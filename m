From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] nsproxy: Check to make sure count is truly zero before
 freeing
Date: Tue, 19 Nov 2013 09:22:54 +0800
Message-ID: <528ABD6E.8020004@cn.fujitsu.com>
References: <20131113160339.7e0726fb@gandalf.local.home>	<877gc5l3hq.fsf@xmission.com> <20131118190457.7ad4e0a0@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Cedric Le Goater <clg@fr.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Clark Williams <williams@redhat.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Steven Rostedt <rostedt@goodmis.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131118190457.7ad4e0a0@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/19/2013 08:04 AM, Steven Rostedt wrote:
> 
> I'll start out saying that this email was a complete oops. I only kept
> it around for reference, as this didn't fix the bug we were seeing, and
> I used this email to just document what I initially thought.
> 

Can you describe the panic situation and the way to reproduce?
it's useful for us to find out the real problem.

Thanks.

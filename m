From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] sch_prio - fix compile warning + some logic
 rearrangement in enqueue
Date: Tue, 29 Jun 2004 14:50:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629145015.41ed8aca.davem@redhat.com>
References: <200406290106.38304.dtor_core@ameritech.net>
	<20040629143202.3ae7093a.davem@redhat.com>
	<1088545330.1157.88.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dtor_core@ameritech.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1088545330.1157.88.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Jun 2004 17:42:10 -0400
jamal <hadi@cyberus.ca> wrote:

> netdev swallowed my response to Dmitry earlier. Bacchus 
> please flog the admin for me.
> This fix will conflict with the other qdisc patch we are discussing.
> Basically thats what my message to Dmitry was earlier.

Should I back Dmitry's change out for now then?

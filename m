From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Long-term TCP connections suffer on high-latency links.
Date: Fri, 30 Jul 2004 09:16:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730091659.0d06352a@dell_ss3.pdx.osdl.net>
References: <Pine.LNX.4.44.0407292206490.9625-100000@fast2.cs.caltech.edu>
	<4109E9E0.9010208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cheng Jin <chengjin@cs.caltech.edu>,
        "'netdev@oss.sgi.com'"
 <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4109E9E0.9010208@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 29 Jul 2004 23:25:36 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Cheng Jin wrote:
> 
> > As of 2.6.6 kernel, TCP Westwood, which mainly addresses issues in 
> > wireless networks, BIC TCP, and TCP Vegas are all included besides TCP 
> > NewReno, although not enabled by default.  The others can be downloaded 
> > from the given websites.  There are probably others that I forgot to 
> > mention.  Apologies to them in advance.
> 
> Any chance Westwood will get into the 2.4 kernel as well?

Both BIC and westwood are in 2.4 now.

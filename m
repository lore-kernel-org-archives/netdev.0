From: "David S. Miller" <davem@redhat.com>
Subject: Re: Linux kernel updates and ip_crossover patch
Date: Thu, 30 Oct 2003 09:53:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030095312.6ef82ff7.davem@redhat.com>
References: <OF5B9BCA99.0441857B-ON65256DCF.004761FF-65256DCF.004828A5@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olh@suse.de, aprasad@in.ibm.com, kaena@us.ibm.com, mfrueh@suse.de,
        olaf@suse.de, netdev@oss.sgi.com, mehul.patel@in.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mehulkumar J Patel <mehul.patel@in.ibm.com>
In-Reply-To: <OF5B9BCA99.0441857B-ON65256DCF.004761FF-65256DCF.004828A5@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Oct 2003 18:33:57 +0530
Mehulkumar J Patel <mehul.patel@in.ibm.com> wrote:

> Basically we need IP CROSSOVER patch to be part of pseries kernel.

This is not how the Linux community works.  You don't say "hey, we
_NEED_ this" and like magic it gets added to the Linux kernel.

Rather, it gets added because someone submits it and the community
sees a need for the feature.

As networking maintainer what I see is that this feature is needed by
and used by only a very small group of people for very specialized
purposes.  Therefore there is no urgency to add this to the kernel
sources any time soon.

You can continue whining, complaining about how much you personally
_NEED_ the ip_crossover patch, but that isn't going to help you
arrive at your goal.  Rather you should spend time explaining to
the community what value it gives to them and why it would be useful
to anything other than very specialized cases and uses.

From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: status of ipchains in 2.6?
Date: Tue, 28 Oct 2003 11:25:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16286.49814.27138.219567@napali.hpl.hp.com>
References: <200310280127.h9S1RM5d002140@napali.hpl.hp.com>
	<20031028015032.734caf21.davem@redhat.com>
	<16286.44522.275791.73904@napali.hpl.hp.com>
	<20031028095747.2cdb57e7.davem@redhat.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031028095747.2cdb57e7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Tue, 28 Oct 2003 09:57:47 -0800, "David S. Miller" <davem@redhat.com> said:

  David> On Tue, 28 Oct 2003 09:56:58 -0800 David Mosberger
  David> <davidm@napali.hpl.hp.com> wrote:

  >> >>>>> On Tue, 28 Oct 2003 01:50:32 -0800, "David S. Miller"
  >> <davem@redhat.com> said:

  >> $ fgrep -i ipchain MAINTAINERS

  David> Try netfilter, ipchains is a part of netfilter.

I took ipchains not being mentioned in MAINTAINERS as a sign that
nobody wanted to hear bug reports about it, hence my choice of lkml.
Perhaps you prefer to flame people rather than making it easier
for them to find the right mailing-list?

	--david

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission #3  for S2io 10GbE driver
Date: Tue, 02 Mar 2004 16:38:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4044FEBA.2050807@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDECB@orsmsx402.jf.intel.com> <4044FABE.9070408@pobox.com> <4044FD93.8030006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4044FD93.8030006@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I see lots of hard-start-xmit errors for e1000 and e100 in 2.4.25,
> and it's very nice to be able to retry.  Lets fix the broken callers
> instead of making the drivers less useful.

Let's fix the broken drivers first.

Like I said, it's a BUG condition.

	Jeff

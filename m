From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: Re: [PATCH] ipv4 tcp autobind problem
Date: Tue, 30 Sep 2003 05:37:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930053757.36965bf3.davem@redhat.com>
References: <20030930024320.5aca8ddc.davem@redhat.com>
	<200309301237.QAA01426@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, hidden@balabit.hu, netdev@oss.sgi.com,
        linux-net@vger.rutgers.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200309301237.QAA01426@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Sep 2003 16:37:48 +0400 (MSD)
kuznet@ms2.inr.ac.ru wrote:

> From this mail I still do not see why autobinding of void socket is so
> bad thing, that it requires marginal fixing at the place which is already
> marginal. What is the real problem?

I think it is some detail about their transparent proxy kernel
hacks, remember that awful stuff? :)

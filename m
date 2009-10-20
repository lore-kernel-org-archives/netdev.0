From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 17:42:17 +0400
Message-ID: <20091020134217.GA5181@lenovo>
References: <200910190002.39937.denys@visp.net.lb> <200910201436.50249.denys@visp.net.lb> <aa79d98a0910200450n1a283f87hf946bb3b756d0bd@mail.gmail.com> <200910201452.58789.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200910201452.58789.denys@visp.net.lb>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Denys Fedoryschenko - Tue, Oct 20, 2009 at 02:52:58PM +0300]
...
| > Thanks a lot! I'll back with new one in a couple of hours. Meanwhile i
| > suppose you may try Michal's patch as well.
| I did, it didn't help.
| Maybe i can run some debugging options in kernel?
| Also i can add debug(printk) lines in kernel if you want, to see where is bug 
| appearing.
| Note, i told to Michal, so will tell here, this pc is hyperthreading P4, as i 
| know it is very good to trigger various SMP race conditions.
| I can try also it with nosmp if u want.
| 

Thanks Denys, I'm preparing new patch (just back from office
and had no inet connection that is why reply is delayed, sorry).

	-- Cyrill

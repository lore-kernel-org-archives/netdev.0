From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [openib-general] Re: LLTX and netif_stop_queue
Date: Wed, 19 Jan 2005 16:47:21 -0800
Message-ID: <20050119164721.34745a81.davem@davemloft.net>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119154132.68f0bb4f.davem@davemloft.net>
	<41EEF52C.8000905@pobox.com>
	<20050119164614.6f74daf3@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, hadi@cyberus.ca, iod00d@hp.com, eric.lemoine@gmail.com,
        roland@topspin.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050119164614.6f74daf3@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 19 Jan 2005 16:46:14 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> But in the end it would be safer than the current LLTX usage in drivers
> which seems like it opening up problems.

Agreed, see my prototype patch in a posting I just made.

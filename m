From: Nix <nix@esperi.org.uk>
Subject: Re: e1000e interface hang on 82574L
Date: Fri, 06 Apr 2012 17:05:53 +0100
Message-ID: <87mx6oluam.fsf@spindle.srvr.nix>
References: <9BBC4E0CF881AA4299206E2E1412B62621F0B1@ORSMSX102.amr.corp.intel.com>
	<4F144A76.3050703@bootc.net> <4F64B4E2.20208@bootc.net>
	<4F64CFCB.7060702@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
	<87r4wova0b.fsf@spindle.srvr.nix>
	<9BBC4E0CF881AA4299206E2E1412B6260E512FB9@ORSMSX102.amr.corp.intel.com>
	<87ehsov6ot.fsf@spindle.srvr.nix>
	<1590F833-7D40-42FE-8FA2-6DCCADF9C6B0@bootc.net>
	<CAErSpo4TJ-9NsD5QTpFi9fsnD9qHt7+Tr5jJHQPuS7vg6ghq_w@mail.gmail.com>
	<20120406134144.GA22526@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Chris Boot <bootc@bootc.net>, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org,
	Bjorn Helgaas <bhelgaas@google.com>, Matthew Garrett <mjg@redhat.com>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120406134144.GA22526@khazad-dum.debian.net> (Henrique de
	Moraes Holschuh's message of "Fri, 6 Apr 2012 10:41:44 -0300")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 6 Apr 2012, Henrique de Moraes Holschuh outgrape:
> You probably need to disable it upstream of the 82574L as well.  Here
> (SuperMicro C7X58) I managed to get it to be stable by telling the BIOS
> to disable L0s and L1 system-wide.
>
> But not all BIOSes will have that option...

Indeed not :( the Tyan S7010 mobo in my headless server can't do it.

-- 
NULL && (void)

------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

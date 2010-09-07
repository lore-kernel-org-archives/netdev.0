From: "Greg Trahair" <Greg.Trahair@tomtom.com>
Subject: Re: [BUG] __vlan_hwaccel_rx system call causes kernel
	panic
Date: Tue, 7 Sep 2010 18:45:48 +0200
Message-ID: <2BB8A93A-8837-4670-A82E-E874625518F0@tomtom.com>
References: <7360C1812CDFF247A3342E16BF5CBE0A01277F6A@NL-EXC-06.intra.local>
	<AANLkTin9ND42s0o-3Wv-vZuG5RTxSheJOCdSnr3qyHX5@mail.gmail.com>
	<80769D7B14936844A23C0C43D9FBCF0F25AF9E8E56@orsmsx501.amr.corp.intel.com>
	<D3EC401C-83E9-4948-A971-F69D2E716592@tomtom.com>
	<80769D7B14936844A23C0C43D9FBCF0F25AF9E9AA7@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0 (iPhone Mail 8A400)
Content-Type: multipart/mixed; boundary="===============4878167718103939530=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Chris Leech <chris.leech@gmail.com>, linux-net@vger.kernel.org
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F25AF9E9AA7@orsmsx501.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4878167718103939530==
Content-Transfer-Encoding: 7bit
Content-Type: multipart/alternative; boundary="Apple-Mail-3-628075682";
	charset="iso-8859-1"


--Apple-Mail-3-628075682
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

That's great news.  I'll create a ticket for Citrix to get thus sorted in Xe=
nServer.

> It looks like the 2.1.9 driver did not have the fix.  The patch that resol=
ved this upstream is located at:
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcom=
mit;h=3D31b24b955c3ebbb6f3008a6374e61cf7c05a193c

--Apple-Mail-3-628075682--


--===============4878167718103939530==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
This SF.net Dev2Dev email is sponsored by:

Show off your parallel programming skills.
Enter the Intel(R) Threading Challenge 2010.
http://p.sf.net/sfu/intel-thread-sfd
--===============4878167718103939530==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4878167718103939530==--

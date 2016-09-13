From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial
        XDP support
Date: Tue, 13 Sep 2016 18:28:03 +0000
Message-ID: <36ECC79A-0810-4D06-A72D-702AD9901E83@intel.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
 <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
 <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160912230745.GA24171@ast-mbp.thefacebook.com>
 <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
 <20160913012815.GB25756@ast-mbp.thefacebook.com>
 <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
 <20160913171340.GA37341@ast-mbp.thefacebook.com>
 <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160913175926.GA38737@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_94F38D14-8A42-404B-BCE2-4F4BB07A3D0D";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "William Tu" <u9012063@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:21476 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755003AbcIMS2F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 14:28:05 -0400
In-Reply-To: <20160913175926.GA38737@ast-mbp.thefacebook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_94F38D14-8A42-404B-BCE2-4F4BB07A3D0D
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> I've looked through qemu and it appears only emulate e1k and tg3.
> The latter is still used in the field, so the risk of touching
> it is higher.

I have no idea what makes you think that e1k is *not* "used in the field".   
I grant you it probably is used more virtualized than not these days, but  
it certainly exists and is used. You can still buy them new at Newegg for  
goodness sakes!

Maybe I'll go home and plug in my old e100 into my machine that still has a  
PCI slot, just for old times sake. Oh darn, I have a SCSI card in that  
slot...
--Apple-Mail=_94F38D14-8A42-404B-BCE2-4F4BB07A3D0D--

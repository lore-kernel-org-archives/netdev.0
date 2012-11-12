From: Jonathan Nieder <jrnieder@gmail.com>
Subject: [3.0.y, 3.2.y, 3.4.y] Re: [PATCH v2] r8169: Fix WoL on
 RTL8168d/8111d.
Date: Mon, 12 Nov 2012 08:38:58 -0800
Message-ID: <20121112163858.GA4343@elie.Belkin>
References: <20121028230523.GA26778@electric-eye.fr.zoreil.com>
 <1351728046-32105-1-git-send-email-kibi@debian.org>
 <20121101222113.GB7708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, stable@vger.kernel.org,
	Cyril Brulebois <kibi@debian.org>, netdev@vger.kernel.org,
	nic_swsd@realtek.com, Hayes Wang <hayeswang@realtek.com>,
	linux-kernel@vger.kernel.org, florent.fourcot@enst-bretagne.fr
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121101222113.GB7708@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu wrote:
> Cyril Brulebois <kibi@debian.org> :

>> This regression was spotted between Debian squeeze and Debian wheezy
>> kernels (respectively based on 2.6.32 and 3.2). More info about
>> Wake-on-LAN issues with Realtek's 816x chipsets can be found in the
>> following thread: http://marc.info/?t=3D132079219400004
>
> David, please apply to -net.

This has been applied as commit b00e69dee4cc in mainline; thanks!

=46ran=C3=A7ois and David, would this be a candidate for inclusion in
3.0- and newer stable kernels?

Jonathan

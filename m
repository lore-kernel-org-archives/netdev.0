From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [3.0.y, 3.2.y, 3.4.y] Re: [PATCH v2] r8169: Fix WoL on RTL8168d/8111d.
Date: Tue, 13 Nov 2012 00:03:39 +0100
Message-ID: <20121112230339.GA28555@electric-eye.fr.zoreil.com>
References: <20121028230523.GA26778@electric-eye.fr.zoreil.com> <1351728046-32105-1-git-send-email-kibi@debian.org> <20121101222113.GB7708@electric-eye.fr.zoreil.com> <20121112163858.GA4343@elie.Belkin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, stable@vger.kernel.org,
	Cyril Brulebois <kibi@debian.org>, netdev@vger.kernel.org,
	nic_swsd@realtek.com, Hayes Wang <hayeswang@realtek.com>,
	linux-kernel@vger.kernel.org, florent.fourcot@enst-bretagne.fr
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121112163858.GA4343@elie.Belkin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jonathan Nieder <jrnieder@gmail.com> :
[...]
> This has been applied as commit b00e69dee4cc in mainline; thanks!
> 
> Fran??ois and David, would this be a candidate for inclusion in
> 3.0- and newer stable kernels?

- 3.0.51
  b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
  aee77e4accbeb2c86b1d294cd84fec4a12dde3bd

- 3.4.18
  0481776b7a70f09acf7d9d97c288c3a8403fbfe4
  b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
  aee77e4accbeb2c86b1d294cd84fec4a12dde3bd

- 3.6.6
  0481776b7a70f09acf7d9d97c288c3a8403fbfe4
  b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
  aee77e4accbeb2c86b1d294cd84fec4a12dde3bd

I'll cook the patches.

-- 
Ueimor

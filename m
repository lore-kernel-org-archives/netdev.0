From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: [ANNOUNCE] Neterion(S2io) 10GbE Xframe Programming Manual posted
Date: Thu, 26 May 2005 20:02:42 -0700
Message-ID: <200505270302.j4R32lVG027513@guinness.s2io.com>
References: <20050316123828.0eb78fd3@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-net@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: <netdev@oss.sgi.com>
In-Reply-To: <20050316123828.0eb78fd3@dxpl.pdx.osdl.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For people interested in "s2io" 10GbE driver, the programming manual for
Xframe-I 10GbE Adapter 
is now available at ftp: ns1.s2io.com user: "linuxdocs" password: "HALdocs"

The relatively small delta between sw-compatible Xframe-II and Xframe-I is
not covered in the document,
but the current driver supports both adapters. Patches for the extra
Xframe-II features will be added over time; 
One of them (UDP Send Offload) was posted earlier today.


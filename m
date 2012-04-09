From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 06/26] bna: remove redundant NULL test before
 release_firmware()
Date: Mon, 9 Apr 2012 14:14:17 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B3A74DF5D5@HQ1-EXCH01.corp.brocade.com>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
 <alpine.LNX.2.00.1204092210470.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "trivial@kernel.org" <trivial@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Juhl <jj@chaosbits.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092210470.13925@swampdragon.chaosbits.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Jesper Juhl [mailto:jj@chaosbits.net]
>Sent: Monday, April 09, 2012 1:50 PM
>To: linux-kernel@vger.kernel.org
>
>release_firmware() does its own NULL test so explicit test before call
>is unneeded.
>
>Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Thanks Jesper!

Acked-by: Rasesh Mody <rmody@brocade.com>

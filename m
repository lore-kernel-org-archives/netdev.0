From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 1/2] net: stmmac: avoid Camelcase naming
Date: Fri, 2 Dec 2016 09:58:46 +0100
Message-ID: <20161202085846.GB20128@Red>
References: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
 <83a25cf8-907b-074e-754c-faa9e641c896@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <83a25cf8-907b-074e-754c-faa9e641c896@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 02, 2016 at 09:44:48AM +0100, Giuseppe CAVALLARO wrote:
> Hello Corentin
> 
> patches look ok, I just wonder if you tested it in case of
> the stmmac is connected to a transceiver. Let me consider it
> a critical part of the driver to properly work.
> 
> Regards
> Peppe
> 

I tested it on a Cubieboard 2 (dwmac-sunxi).
What do you mean by "connected to a transceiver" ? an external PHY ?

Regards

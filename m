From: "Hebbar, Gururaja" <gururaja.hebbar@ti.com>
Subject: RE: [net-next resend PATCH 1/6] net: cpsw: enhance pinctrl support
Date: Thu, 23 May 2013 11:28:38 +0000
Message-ID: <1BAFE6F6C881BF42822005164F1491C33EBF928C@DBDE04.ent.ti.com>
References: <1369130103-743-1-git-send-email-mugunthanvnm@ti.com>
	<1369130103-743-2-git-send-email-mugunthanvnm@ti.com>
 <20130522.235741.135665074490271750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"benoit.cousson@linaro.orgm" <benoit.cousson@linaro.orgm>,
	"paul@pwsan.com" <paul@pwsan.com>
To: David Miller <davem@davemloft.net>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130522.235741.135665074490271750.davem@davemloft.net>
Content-Language: en-US
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 12:27:41, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Tue, 21 May 2013 15:24:58 +0530
> 
> > +		priv->pins_default = pinctrl_lookup_state(priv->pinctrl,
> > +						PINCTRL_STATE_DEFAULT);
> 
> This is not indented correctly.
> 
> Argument on the second, and subsequent, lines of a function call
> must start at the first column after the openning parenthesis of
> the function call itself.

Well, if I am correct, doing so will make the line cross 80 character limit.
If you could (please I ask), can you let me know how it can be handled in 
above situation. I will make the changes/corrections and re-send it.

Thanks a lot in advance.

> 
> Please audit for this problem in your entire patch series, fix
> it up, and resubmit the full set of patches.
> 
> Thanks.
> 


Regards, 
Gururaja

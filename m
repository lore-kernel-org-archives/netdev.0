From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: Re: [PATCH v3 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Fri, 24 Feb 2017 11:35:17 +0530
Message-ID: <20170224060513.GA26086@microsemi.com>
References: <1486474826-29426-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20170215164540.eok7bnudfffzoyi4@rob-hp-laptop>
 <20170216090646.GA29082@microsemi.com>
 <CAL_JsqJLCe1O7Bv526zAY-s-R1DcnA2O0bpx48dTFGSgeu-Edw@mail.gmail.com>
Reply-To: <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAL_JsqJLCe1O7Bv526zAY-s-R1DcnA2O0bpx48dTFGSgeu-Edw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

Thank you for code review comments.

On Tue, Feb 21, 2017 at 10:42:38AM -0600, Rob Herring wrote:
> EXTERNAL EMAIL
> 
> 
> > Do i need to change from  "vsc8531, led-0-mode" to "mscc, led-0-mode"
> > Is this your suggestion?
> 
> Well, there shouldn't be a space there, but yess, mscc is the prefix.
> 
> Read my original comments. I also suggested combining this to a single property.
> 

Accepted your comment.
Fix the combining into single property and change prefix to mscc.
I sent the latest code for review. Please review and send your comments.

> Rob

---
Thanks,
Raju
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

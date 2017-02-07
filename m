From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] dt-bindings: net: remove reference to fixed link support
Date: Tue, 7 Feb 2017 12:46:43 -0600
Message-ID: <20170207184643.janfd47zureahrc4@rob-hp-laptop>
References: <1486054064-31093-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20170203.155938.1981764313840579677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org, jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
        hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170203.155938.1981764313840579677.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 03, 2017 at 03:59:38PM -0500, David Miller wrote:
> From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> Date: Thu,  2 Feb 2017 17:47:44 +0100
> 
> > Contrary to what the Device Tree binding indicates, the binding for the
> > PPv2 network device currently doesn't provide any fixed link
> > functionality. This commit adjusts the Device Tree binding documentation
> > accordingly.
> > 
> > Reported-by: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
> > Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> 
> What tree is this intended to go into?  Mine?

I've applied to DT tree.

Rob

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

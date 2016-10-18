From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] net: phy: Add Fast Link Failure - 2 set
 driver for Microsemi PHYs.
Date: Tue, 18 Oct 2016 13:49:29 +0200
Message-ID: <20161018114929.GO26778@lunn.ch>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161014120228.GF5822@lunn.ch>
 <20161017081312.GB2365@microsemi.com>
 <838C6202-9B7D-4AFA-B163-55515044FA4F@gmail.com>
 <20161018103413.GA31087@microsemi.com>
 <20161018105820.GM26778@lunn.ch>
 <20161018113043.GA19357@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161018113043.GA19357-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Do i need to change Ethtool application and submit along with 
> downshift driver patch (i.e. ethtool.c, phy.c, cpsw.c and mscc.c changes) ? 

Yes, please submit two patchset. One patchset for ethtool and its man
page and a second patchset for all the kernel changes.

     Thanks
	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

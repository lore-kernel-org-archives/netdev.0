From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Fri, 10 Jun 2016 14:09:54 +0200
Message-ID: <6ab2c663-5559-5818-5357-6801ff452dfb@st.com>
References: <1465268516-31480-1-git-send-email-thloh@altera.com>
 <ab65dd4e-830a-c774-c8fa-1adfb3be1a69@st.com>
 <1465451310.4467.21.camel@ubuntu>
 <ac036ba2-c9ce-1fb4-89e3-9af499954907@st.com>
 <1465539145.4467.42.camel@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <thloh85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Chee Nouk Phoon <cnphoon-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
To: Tien Hock Loh <thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465539145.4467.42.camel@ubuntu>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Tien Hock

On 6/10/2016 8:12 AM, Tien Hock Loh wrote:
>>> Yeah the PCS support for TSE is Altera. To avoid confusion, let's rename
>>> > > them, would altr_tse_pcs.[hc] be good? I don't think creating a
>>> > > sub-directory with only 2 files is necessary though.
>> >
>> > ok for two files w/o sub-dir.
>> >
>>> > >
>>> > > I see that stmmac.txt is generic, and other vendor's PCS support
>>> > > documents their specific uses in their own *-dwmac.txt (eg.
>>> > > rockchip-dwmac.txt). Is this not the case?
>> >
>> > yes you can use this name convention. I let you decide.
> What I meant was we've documented the bindings in socfpga-dwmac.txt for
> platform specific bindings, and I won't be updating stmmac.txt because
> that is the generic driver binding. Agree?

ok if you documented all in socfpga-dwmac.txt

peppe

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

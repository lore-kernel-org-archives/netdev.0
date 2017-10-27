From: Jose Abreu <Jose.Abreu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation for
 TSN parameters
Date: Fri, 27 Oct 2017 14:50:05 +0100
Message-ID: <b4c76843-761c-4a51-f8c5-0e058cfd9929@synopsys.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
 <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427@gmail.com>
 <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
 <20171026090308.GD20299@lunn.ch>
 <867d6d43-9df7-4097-db5a-f2049236394f@synopsys.com>
 <20171026215629.GB8489@lunn.ch>
 <e14b8b79-465b-9cf3-4ecc-52de4781d9c0@synopsys.com>
 <de8781f7-39b1-8ba9-d0d0-ba89834697d3@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <de8781f7-39b1-8ba9-d0d0-ba89834697d3-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Peppe,

On 27-10-2017 13:29, Giuseppe CAVALLARO wrote:
> Hello
>
> On 10/27/2017 11:05 AM, Jose Abreu wrote:
>> I think we should take advantage of the fact that this is working
>> and ready to be merged. Its just HW configuration but maybe it
>> can serve as momentum for other drivers to also integrate this?
>
> Let me propose to have it now in the next-next.
>
> This support is for dwmac 5.x so no disturb for the common
> driver APIs and there is no risk to have regressions, IMO.
>
> IIUC, you already tested it on a real environment that
> sounds to be very good progress.

Ok, I will drop this documentation patch and the DT parsing and
send a new version.

Best Regards,
Jose Miguel Abreu

>
> Regards
> Peppe
>
>> Best Regards,
>> Jose Miguel Abreu
>
>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

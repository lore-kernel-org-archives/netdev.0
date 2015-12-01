From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] ravb: add R8A7791 support
Date: Tue, 1 Dec 2015 16:13:01 +0300
Message-ID: <565D9CDD.1070507@cogentembedded.com>
References: <1661514.u50jDu7LON@wasted.cogentembedded.com>
 <20151201074450.GA31496@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151201074450.GA31496-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/1/2015 10:44 AM, Simon Horman wrote:

>> Add support  for yet another ARM member of the R-Car family, R-Car M2-W,
>> also known as R8A7791.
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
>>
>> ---
>> The patch is against DaveM's 'net-next.git' repo but I wouldn't mind if it's
>> applied to 'net.git' instead. :-)
>>
>> Changes in version 2:
>> - fixed the SoC name in the changelog.
>
> I have no particular problem with this patch but as mentioned elsewhere I
> have been working on a more comprehensive patchset which I have now posted as:
>
> "[PATCH 0/2 net-next] ravb: More compat strings"

    Dave, please ignore my patch in favor of Simon's series (after it gets 
fixed up, of course).

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

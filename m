From: Joel Jaeggli <joelja@darkwing.uoregon.edu>
Subject: Re: The ultimate TOE design
Date: Fri, 24 Sep 2004 12:39:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0409241119350.30262@twin.uoregon.edu>
References: <20040924130738.GB24093@xi.wantstofly.org>
 <200409241321.i8ODLf39012346@guinness.s2io.com> <20040924180915.GB26922@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Leonid Grossman <leonid.grossman@s2io.com>,
        "'David S. Miller'" <davem@davemloft.net>,
        "'Jeff Garzik'" <jgarzik@pobox.com>, alan@lxorguk.ukuu.org.uk,
        paul@clubi.ie, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20040924180915.GB26922@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004, Lennert Buytenhek wrote:

>
>> I was referring to the server side.
>> One can certanly build a 10GbE box based on IPX2800 (or some other parts),
>> but at 17-25W it is not usable in NICs since the entire PCI card budget is
>> less than that - nothing left for 10GbE PHY, memory, etc.

I have a graphics card which requires two four pin molex power connectors, 
going back in time there have allway been certain perphiral cards which 
required external (non-bus supplied power sources for whatever reason) 
(hard-drive on a card, sparc on a card, pc on a card, early 90's hardware 
mpeg encoder, data collection device, remote mangement card, graphics card 
in modern mac etc), it's obviously not a general solution, but it's been 
done frequently enough that it shouldn't just be discarded out of hand.

> Ah, ok, that makes sense.  As someone else also noted, the IXP2800
> only has a 64/66 PCI interface anyway, so it wouldn't really be
> suitable for the task you were referring to.
>
>
> cheers,
> Lennert
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

-- 
-------------------------------------------------------------------------- 
Joel Jaeggli  	       Unix Consulting 	       joelja@darkwing.uoregon.edu 
GPG Key Fingerprint:     5C6E 0104 BAF0 40B0 5BD3 C38B F000 35AB B67F 56B2

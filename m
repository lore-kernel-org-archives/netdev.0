From: Kumar Gala <kumar.gala@freescale.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Mon, 16 Aug 2004 11:31:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C06D6C4A-EFA1-11D8-B1A9-000393DBC2E8@freescale.com>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com> <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com> <1089170282.1038.80.camel@jzny.localdomain> <20040707032913.GA1822@havoc.gtf.org> <FBF8DCB8-E4D1-11D8-999F-000393C30512@freescale.com> <20040802231112.GA890@havoc.gtf.org> <4819CC65-E4DB-11D8-999F-000393C30512@freescale.com> <5016F2DB-E66A-11D8-B1F6-000393C30512@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
        Andy Fleming <AFLEMING@motorola.com>,
        Kumar Gala <kumar.gala@motorola.com>,
        "<netdev@oss.sgi.com>" <netdev@oss.sgi.com>, jamal <hadi@cyberus.ca>,
        Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <5016F2DB-E66A-11D8-B1F6-000393C30512@freescale.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

Now that 2.6.8.1 is out what is the status of reviewing andy's changes?

thanks

- kumar

On Aug 4, 2004, at 6:02 PM, Andy Fleming wrote:

> Ok, while we're still waiting, I found a couple of bugs, so here's 
> another patch: same as before, only correct (I hope)
> Andy
> On Aug 2, 2004, at 18:25, Andy Fleming wrote:
>> D'oh!
>>
>> <patch_2004_8_2>On Aug 2, 2004, at 18:11, Jeff Garzik wrote:
>>> On Mon, Aug 02, 2004 at 05:19:13PM -0500, Andy Fleming wrote:
>>>> Here's an updated patch which fixes module support which does this:
>>>>
>>>>   * More cleanup/minor bug fixes
>>>>   * Added locking to PHY read/write wrappers
>>>>   * Fixed module support
>>>>   * Removed fastroute code
>>>>
>>>> As before, this patch replaces the previous ones I have submitted.
>>>
>>> the patch?  :)
>>>
>>> 	Jeff
>
> <patch_2004_8_4>

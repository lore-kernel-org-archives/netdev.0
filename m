From: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH 4/7] net: emaclite: Add support for little-endian platforms
Date: Wed, 29 Sep 2010 17:33:23 +1000
Message-ID: <4CA2EBC3.3030509@monstr.eu>
References: <1285739538-29058-4-git-send-email-monstr@monstr.eu>	<1285739538-29058-5-git-send-email-monstr@monstr.eu>	<20100929061146.GA2439@angua.secretlab.ca>
	<20100928.232722.189705899.davem@davemloft.net>
Reply-To: monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, duyl-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, linnj-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	edgar.iglesias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, john.williams-g5w7nrANp4BDPfheJLI6IQ@public.gmane.org
To: microblaze-uclinux-rVRm/Wmeqae7NGdpmJTKYQ@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20100928.232722.189705899.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org



David Miller wrote:
> From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> Date: Wed, 29 Sep 2010 15:11:46 +0900
> 
>> On Wed, Sep 29, 2010 at 03:52:15PM +1000, Michal Simek wrote:
>>> Upcomming Microblaze is little endian that's why is necessary
>>> to fix protocol and length loading.
>>>
>>> Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
>>> CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>>> CC: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
>>> CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> CC: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>> This should go via davem, but it looks correct to me.
>>
>> Acked-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> 
> It doesn't need to, the microblaze guys can integrate this directly:
> 
> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Thanks for ACKs. I will add them and will take care about it.

Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian

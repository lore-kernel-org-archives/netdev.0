From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool get/set
 phy setting
Date: Fri, 8 Mar 2013 20:38:27 +0530
Message-ID: <5139FEEB.6060506@ti.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
 <1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
 <8762135on4.fsf@dell.be.48ers.dk>
 <1362686350.2936.43.camel@bwh-desktop.uk.solarflarecom.com>
 <513991E6.5080400@ti.com>
 <1362754401.3248.8.camel@bwh-desktop.uk.solarflarecom.com>
 <87ip523pc3.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <87ip523pc3.fsf-D6SC8u56vOOJDPpyT6T3/w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 3/8/2013 8:34 PM, Peter Korsgaard wrote:
>>>>>> "Ben" == Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org> writes:
> Hi,
>
>   Ben> The 'active slave' property would also be needed for the SIOCGMIIPHY
>   Ben> ioctl and not just ethtool.  But it's really quite arbitrary.  Perhaps
>   Ben> each of them should have their own net device (as with DSA).
>
> Indeed, I think that would simplify all of this quite a bit.
>
I will update this in the next patch series

Regards
Mugunthan V N

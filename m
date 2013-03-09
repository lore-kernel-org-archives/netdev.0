From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool
 get/set phy setting
Date: Sat, 9 Mar 2013 07:51:06 +0100
Message-ID: <20130309065106.GA2588@netboy.at.omicron.at>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
 <1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
 <8762135on4.fsf@dell.be.48ers.dk>
 <1362686350.2936.43.camel@bwh-desktop.uk.solarflarecom.com>
 <513991E6.5080400@ti.com>
 <1362754401.3248.8.camel@bwh-desktop.uk.solarflarecom.com>
 <5139FE94.6090004@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5139FE94.6090004-l0cyMroinI0@public.gmane.org>
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

On Fri, Mar 08, 2013 at 08:37:00PM +0530, Mugunthan V N wrote:
> 
> As Peter Korsgaard mentioned we need to have infrastructure to handle CPSW
> kind of hardware.

This will be a big job, I think, but I agree that it is worth doing.

I can think of one other switch-with-host-port device. Maybe we should
start off by making a list of actual products and their capabilities,
in order to get an overall idea of what we would need to develop.

Thanks,
Richard

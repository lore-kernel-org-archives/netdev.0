From: Bastien Nocera <hadess@hadess.net>
Subject: Re: [PATCH] rfkill-gpio: Add support for the Realtek 8723 BT
Date: Wed, 15 Jul 2015 08:30:30 +0200
Message-ID: <1436941830.20249.64.camel@hadess.net>
References: <1436825494.20249.47.camel@hadess.net>
	 <55A50C82.4040107@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A50C82.4040107@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-14 at 08:20 -0500, Larry Finger wrote:
> On 07/13/2015 05:11 PM, Bastien Nocera wrote:
> > http://thread.gmane.org/gmane.linux.kernel.wireless.general/127706/
> > focu
> > s=127896
> > 
> > Signed-off-by: Bastien Nocera <hadess@hadess.net>
> 
> Bastien,
> 
> The subject of this patch needs a bit more detail. I know that you 
> mean the 
> RTL8723B versions of the Bluetooth devices. The subject should say 
> this.
> 
> The commit message needs a bit more detail. Referencing the E-mail 
> thread is OK, 
> but a bit more is needed. What fails without this change?

Nothing yet, as the current Bluetooth support for this device is
completely in user-space, and doesn't sync up with rfkill.

> To help keep that patches straight, change the next submission to say 
> "[PATCH 
> V2]" in the subject. In addition, after the ---, add a section saying 
> what 
> changed in V2. That info is not retained in the final commit message 
> in the 
> repo, but it can be very useful to a maintainer.


I already submitted this patch? I certainly forgot doing so :)

From: Bastien Nocera <hadess@hadess.net>
Subject: Re: [PATCH] rfkill-gpio: Add support for the Realtek 8723 BT
Date: Wed, 15 Jul 2015 08:32:29 +0200
Message-ID: <1436941949.20249.65.camel@hadess.net>
References: <1436825494.20249.47.camel@hadess.net>
	 <55A50C82.4040107@lwfinger.net>
	 (sfid-20150714_152007_936504_073B238A) <1436880105.11226.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436880105.11226.2.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-14 at 15:21 +0200, Johannes Berg wrote:
> On Tue, 2015-07-14 at 08:20 -0500, Larry Finger wrote:
> > On 07/13/2015 05:11 PM, Bastien Nocera wrote:
> > > http://thread.gmane.org/gmane.linux.kernel.wireless.general/12770
> > > 6/
> > > focu
> > > s=127896
> > > 
> > > Signed-off-by: Bastien Nocera <hadess@hadess.net>
> > 
> > Bastien,
> > 
> > The subject of this patch needs a bit more detail. I know that you 
> > mean the 
> > RTL8723B versions of the Bluetooth devices. The subject should say 
> > this.
> > 
> > The commit message needs a bit more detail. Referencing the E-mail 
> > thread is OK, 
> > but a bit more is needed. What fails without this change?
> > 
> > To help keep that patches straight, change the next submission to 
> > say 
> > "[PATCH 
> > V2]" in the subject. In addition, after the ---, add a section 
> > saying 
> > what 
> > changed in V2. That info is not retained in the final commit 
> > message 
> > in the 
> > repo, but it can be very useful to a maintainer.
> > 
> 
> And while at it, please use links that include the message-id (e.g.
> mid.gmane.org) so it's searchable even if the archive disappears.

Didn't know that service, thanks.

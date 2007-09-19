From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'ssb-drivers' branch of
	wireless-2.6
Date: Wed, 19 Sep 2007 17:27:56 -0400
Message-ID: <20070919212756.GA3136@tuxdriver.com>
References: <20070919204428.GE5483@tuxdriver.com>
	<20070919.142529.03110023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, gregkh@suse.de,
	linux-wireless@vger.kernel.org,
	linux-usb-users@lists.sourceforge.net, mb@bu3sch.de,
	zambrano@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-usb-users-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070919.142529.03110023.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-users>,
	<mailto:linux-usb-users-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-users>
List-Post: <mailto:linux-usb-users@lists.sourceforge.net>
List-Help: <mailto:linux-usb-users-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-users>,
	<mailto:linux-usb-users-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-users-bounces@lists.sourceforge.net
Errors-To: linux-usb-users-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 02:25:29PM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Wed, 19 Sep 2007 16:44:28 -0400

> > The second patch adds a driver for a USB OHCI device which lives on
> > the SSB bus.  Again, this is found on a number of SoC devices used
> > especially in wireless routers and APs.

> I'll let Greg take in the OHCI thing.  I would suggest that he
> queue it up, and then once I get the net-2.6.24 tree into the
> merge window (which contains the SSB stack) he can push the
> OHCI change in afterwards.

ACK

-- 
John W. Linville
linville@tuxdriver.com

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
Linux-usb-users@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-users

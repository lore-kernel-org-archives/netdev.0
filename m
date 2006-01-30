From: Robert Love <rml@novell.com>
Subject: Re: [2.6.15 patch] wireless/airo: add IWENCODEEXT and IWAUTH support
Date: Mon, 30 Jan 2006 14:04:05 -0500
Message-ID: <1138647845.23884.76.camel@betsy.boston.ximian.com>
References: <1138640281.12551.5.camel@dhcp83-115.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	breed@users.sourceforge.net, networkmanager-list@gnome.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <networkmanager-list-bounces@gnome.org>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1138640281.12551.5.camel@dhcp83-115.boston.redhat.com>
List-Unsubscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=unsubscribe>
List-Archive: <http://mail.gnome.org/archives/networkmanager-list>
List-Post: <mailto:networkmanager-list@gnome.org>
List-Help: <mailto:networkmanager-list-request@gnome.org?subject=help>
List-Subscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=subscribe>
Sender: networkmanager-list-bounces@gnome.org
Errors-To: networkmanager-list-bounces@gnome.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-01-30 at 11:58 -0500, Dan Williams wrote:

> This patch adds IWENCODEEXT and IWAUTH support to the airo driver for
> WEP and unencrypted operation.  No WPA though.  It allows the driver to
> operate more willingly with wpa_supplicant and NetworkManager.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>

Tested on my airo and works.

Acked-by: Robert Love <rml@novell.com>

	Robert Love

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 net-next 9/9] staging: vt6655: inherit
 addr_assign_type along with dev_addr
Date: Fri, 30 Aug 2013 09:56:42 -0700
Message-ID: <20130830165642.GB8151@kroah.com>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
 <1377878932-26881-10-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Forest Bond <forest@alittletooquiet.net>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1377878932-26881-10-git-send-email-bjorn@mork.no>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 30, 2013 at 06:08:52PM +0200, Bj=F8rn Mork wrote:
> A device inheriting a random or set address should reflect this in
> its addr_assign_type.
> =

> Cc: Forest Bond <forest@alittletooquiet.net>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

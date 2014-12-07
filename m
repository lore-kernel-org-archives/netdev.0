From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 0/20] fix misspelling of current function in string
Date: Mon, 8 Dec 2014 10:44:40 +1100
Message-ID: <CAGRGNgWDJqV=XD+6q26Ma=m1sEi1kvLWsjq6=RjRVSFTxow0Qg@mail.gmail.com>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 linux-samsung-soc@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>,
 linux-pci@vger.kernel.org, linux-wireless <linux-wireless@vger.kernel.org>,
 intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org,
 kernel-janitors@vger.kernel.org,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 dri-devel@lists.freedesktop.org, netdev <netdev@vger.kernel.org>,
 linux-mtd@lists.infradead.org, linux@rasmusvillemoes.dk,
 Joe Perches <joe@perches.com>, "Mailing List,
 Arm" <linux-arm-kernel@lists.infradead.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hi Julia,

On Mon, Dec 8, 2014 at 6:20 AM, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> These patches replace what appears to be a reference to the name of the
> current function but is misspelled in some way by either the name of the
> function itself, or by %s and then __func__ in an argument list.

Would there be any value in doing this for _all_ cases where the
function name is written in a format string?

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/

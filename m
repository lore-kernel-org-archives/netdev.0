From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH V3 00/29] bitops: add parity functions
Date: Sun, 17 Apr 2016 05:38:57 -0700
Message-ID: <20160417123857.GD33215@dtor-ws>
References: <1460601525-3822-1-git-send-email-zengzhaoxiu@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
        Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>,
        adi-buildroot-devel@lists.sourceforge.net,
        Andrew Morton <akpm@linux-foundation.org>,
        Anton Blanchard <anton@samba.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
        Borislav Petkov <bp@suse.de>,
        Bruce Allan <bruce.w.allan@intel.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        David Herrmann <dh.herrmann@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Denys Vlasenko <dvlasenk@redhat.com>,
        Duson Lin <dusonlin@emc.com.tw>,
        Guenter Roeck <linux@roeck-us.net>,
        Hans de Goede <hdegoede@redhat.com>,
        Hans Verkuil <hans.verkuil@cisco.com>,
        Hartmut Knaack <knaack.h@gmx.de>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Hendrik Brueckne
To: zengzhaoxiu@163.com
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1460601525-3822-1-git-send-email-zengzhaoxiu@163.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2016 at 10:36:41AM +0800, zengzhaoxiu@163.com wrote:
>  drivers/input/joystick/grip_mp.c             |  16 +--
>  drivers/input/joystick/sidewinder.c          |  24 +----
>  drivers/input/mouse/elantech.c               |  10 +-
>  drivers/input/mouse/elantech.h               |   1 -
>  drivers/input/serio/ams_delta_serio.c        |   8 +-
>  drivers/input/serio/pcips2.c                 |   2 +-
>  drivers/input/serio/sa1111ps2.c              |   2 +-

For input bits:

Acked-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>

Thanks.

-- 
Dmitry

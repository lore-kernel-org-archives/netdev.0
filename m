From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH 00/33] devm improvement series, part 1, take 2
Date: Thu, 16 May 2013 18:25:42 +0530
Message-ID: <CAKohpokUy7QfvKkzGH025Zs5VkUhr8zRLeo3caG3LAnLfptzww@mail.gmail.com>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
        <1368705452.15764.217.camel@sauron.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Wolfram Sang <wsa@the-dreams.de>, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
        linux-usb@vger.kernel.org,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        Matt Mackall <mpm@selenic.com>, linux-fbdev@vger.kernel.org,
        dri-devel@lists.freedesktop.org, Jaroslav Kysela <perex@perex.cz>,
        linux-ide@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
        netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
        linux-i2c@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
        Wan ZongShun <mcuos.com@gmail.com>, ac100@lists.launchpad.net,
        devel@driverdev.osuosl.org, Kukjin Kim <kgene.kim@samsung.com>,
        Russell King <linux@arm.linux.org.uk>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Florian Tobias Schandin
To: dedekind1@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1368705452.15764.217.camel@sauron.fi.intel.com>
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

On 16 May 2013 17:27, Artem Bityutskiy <dedekind1@gmail.com> wrote:
> On Thu, 2013-05-16 at 13:15 +0200, Wolfram Sang wrote:
>> Despite various architectures and platform dependencies, I managed to
>> compile
>> test 45 out of 57 modified files locally using heuristics and
>> defconfigs.
>> If somebody knows how to create a minimal .config with a certain
>> kconfig symbol
>> (and its dependencies) set, I'd love to hear about it.
>
> If you find this out, please, share!

Are you guys looking for "make savedefconfig" ??

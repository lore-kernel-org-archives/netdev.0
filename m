From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 00/28] MIPS Boston board support
Date: Thu, 10 Dec 2015 17:26:31 +0100
Message-ID: <CACRpkdb2YhSbaYUXh4Dz7juObHxmWLc8Gj6UmkJ=Nv69UNfaPA@mail.gmail.com>
References: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
        <20151130163413.GB1929@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul Burton <paul.burton@imgtec.com>,
        Linux MIPS <linux-mips@linux-mips.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Joshua Kinard <kumba@gentoo.org>,
        Alessandro Zummo <a.zummo@towertech.it>,
        Jiri Slaby <jslaby@suse.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        Kumar Gala <galak@codeaurora.org>,
        Yijing Wang <wangyijing@huawei.com>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Rob Herring <robh+dt@kernel.org>,
        John Crispin <blogic@openwrt.org>,
        Jayachandran C <jchandra@broadcom.com>,
        "linux-spi@vger.kernel.org" <linux-spi@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Ray Jui <rjui@broadcom.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Tejun Heo <tj@kernel.org>,
        Michal
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20151130163413.GB1929@sirena.org.uk>
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

On Mon, Nov 30, 2015 at 5:34 PM, Mark Brown <broonie@kernel.org> wrote:
> On Mon, Nov 30, 2015 at 04:21:25PM +0000, Paul Burton wrote:
>> This series introduces support for the Imagination Technologies MIPS
>> Boston development board. Boston is an FPGA-based development board
>> akin to the much older Malta board, built around a Xilinx FPGA running
>> a MIPS CPU & other logic including a PCIe root port connected to an
>> Intel EG20T Platform Controller Hub. This provides a base set of
>> peripherals including SATA, USB, SD/MMC, ethernet, I2C & GPIOs. PCIe
>> slots are also present for expansion.
>
> This is an insanely big CC list :(
>
> What are the interdependencies here - does this really need to be one
> patch series or can the individual driver changes go in separately?

I took the two GPIO patches and ran off with them at least.

Yours,
Linus Walleij

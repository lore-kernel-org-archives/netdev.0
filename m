From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile
Date: Tue, 15 Aug 2017 10:01:05 -0400
Message-ID: <CADVnQyniFPUFFKucKudG1bjhWWVsy7zGBEcVvBEErVWBCjVRNA@mail.gmail.com>
References: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Mohamed Othman <mothman@upm.edu.my>,
        Borhanuddin Ali <borhan@upm.edu.my>,
        Zurina Hanapi <zurinamh@upm.edu.my>
To: mohamedalrshah <mohamed.a.alrshah@ieee.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2017 at 9:08 AM, mohamedalrshah
<mohamed.a.alrshah@ieee.org> wrote:
> This commit implements a new TCP congestion control algorithm, namely Agile-SD.

Also, please use a summary line for your patch that is more in keeping
with Linux style, using spaces rather than dashes, and leading with
tcp: or tcp_agile_sd:. For example:
  tcp: add Agile SD TCP congestion control module

And please read:
  https://www.kernel.org/doc/html/latest/process/submitting-patches.html

Thanks,
neal

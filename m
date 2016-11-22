From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [net] 34fad54c25: kernel BUG at include/linux/skbuff.h:1935!
Date: Tue, 22 Nov 2016 15:30:31 -0800
Message-ID: <CA+55aFycaFHqncv1TQLSxXiy9k8n7phe=OWAuv_mKEKAkVfNNQ@mail.gmail.com>
References: <582b7c30.nXQXP2V4/6pFiYwt%xiaolong.ye@intel.com>
 <CA+55aFxV7Bq583QOdYauuo2jY9EkAmgnceBukrN27ArjzFszYg@mail.gmail.com> <CANn89i+B8F8thJRCdNPHA=BddTTxHCHz+xkvT_wuZ+b8osoTVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel test robot <xiaolong.ye@intel.com>,
        David Miller <davem@davemloft.net>, LKP <lkp@01.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
        Andre Noll <maan@tuebingen.mpg.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89i+B8F8thJRCdNPHA=BddTTxHCHz+xkvT_wuZ+b8osoTVQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 2:28 PM, Eric Dumazet <edumazet@google.com> wrote:
>
> This is fixed by :
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=c9b8af1330198ae241cd545e1f040019010d44d9

Thanks guys. This was one of the less esoteric-looking regressions, so
I'm happy to hear it's solved.

             Linus

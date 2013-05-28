From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/core/sock.c: add missing VSOCK string in af_family_*_key_strings
Date: Tue, 28 May 2013 21:58:52 +0400
Message-ID: <51A4F05C.90001@cogentembedded.com>
References: <1369753364-10043-1-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <edumazet@google.com>,
	Li Zefan <lizefan@huawei.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369753364-10043-1-git-send-email-federico.vaga@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 28-05-2013 19:02, Federico Vaga wrote:

> The three arrays of strings: af_family_kay_strings,

    s/kay/key/. Maybe whoever applies this could fix the typo...

> af_family_slock_key_strings and af_family_clock_key_strings have not
> VSOCK's string

> Signed-off-by: Federico Vaga <federico.vaga@gmail.com>

WBR, Sergei

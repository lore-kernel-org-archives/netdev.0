From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: add mod default A and X test cases
Date: Wed, 04 Nov 2015 21:15:21 +0100
Message-ID: <563A6759.3060405@iogearbox.net>
References: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>, ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/04/2015 08:36 PM, Yang Shi wrote:
> When running "mod X" operation, if X is 0 the filter has to be halt.
> Add new test cases to cover A = A mod X if X is 0, and A = A mod 1.
>
> CC: Xi Wang <xi.wang@gmail.com>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

LGTM!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

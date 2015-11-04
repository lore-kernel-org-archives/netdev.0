From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH] bpf: add mod default A and X test cases
Date: Wed, 4 Nov 2015 14:05:05 -0800
Message-ID: <CABg9mcsQnZrwWSck85JD6djoysq69unTWCeLzCTOb7oD7mtCVQ@mail.gmail.com>
References: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 4, 2015 at 11:36 AM, Yang Shi <yang.shi@linaro.org> wrote:
> When running "mod X" operation, if X is 0 the filter has to be halt.
> Add new test cases to cover A = A mod X if X is 0, and A = A mod 1.
>
> CC: Xi Wang <xi.wang@gmail.com>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---

Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>

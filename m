From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: add mod default A and X test cases
Date: Wed, 4 Nov 2015 12:25:47 -0800
Message-ID: <20151104202546.GA47322@ast-mbp.thefacebook.com>
References: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, zlim.lnx@gmail.com,
	xi.wang@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 04, 2015 at 11:36:37AM -0800, Yang Shi wrote:
> When running "mod X" operation, if X is 0 the filter has to be halt.
> Add new test cases to cover A = A mod X if X is 0, and A = A mod 1.
> 
> CC: Xi Wang <xi.wang@gmail.com>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>

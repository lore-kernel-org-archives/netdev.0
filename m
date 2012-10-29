From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: must split too big fragments
Date: Mon, 29 Oct 2012 19:13:21 +0100
Message-ID: <1351534401.12280.132.camel@edumazet-glaptop>
References: <1948210032.25549736.1351533171670.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	jongman heo <jongman.heo@samsung.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	David Miller <davem@davemloft.net>
To: Bhavesh Davda <bhavesh@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1948210032.25549736.1351533171670.JavaMail.root@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-10-29 at 10:52 -0700, Bhavesh Davda wrote:
> LGTM. Thanks for doing this! Did you do any performance testing with this patch?
> 
> Reviewed-by: Bhavesh Davda <bhavesh@vmware.com>

Just to be clear : I coded the patch and compiled it, but didnt test it.

Jongman did the tests ;)

Thanks !

From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [patch] sfc: cleanup a condition in efx_udp_tunnel_del()
Date: Wed, 22 Mar 2017 17:41:16 -0400
Message-ID: <adcdb8bb-b870-e023-4b0a-9d11efe099e4@redhat.com>
References: <20170322091002.GB14520@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170322091002.GB14520@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-03-22 5:10 AM, Dan Carpenter wrote:
> Presumably if there is an "add" function, there is also a "del"
> function.  But it causes a static checker warning because it looks like
> a common cut and paste bug.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Agreed, looks like a cut-n-paste buglet.

Acked-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com

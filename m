From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] net: docs: document multiqueue tuntap API
Date: Wed, 06 Mar 2013 13:16:11 +0800
Message-ID: <5136D11B.9050905@redhat.com>
References: <1362539123-24863-1-git-send-email-jasowang@redhat.com> <20130305.235401.548455441771005291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: maxk@qti.qualcomm.com, rob@landley.net, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mst@redhat.com, hkchu@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130305.235401.548455441771005291.davem@davemloft.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/06/2013 12:54 PM, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed,  6 Mar 2013 11:05:23 +0800
>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Please fix these warnings emitted by GIT:
>
> Applying: net: docs: document multiqueue tuntap API
> /home/davem/src/GIT/net/.git/rebase-apply/patch:31: space before tab in indent.
>   	struct ifreq ifr;
> /home/davem/src/GIT/net/.git/rebase-apply/patch:32: space before tab in indent.
>   	int fd, err, i;
> /home/davem/src/GIT/net/.git/rebase-apply/patch:34: space before tab in indent.
>   	if (!dev)
> /home/davem/src/GIT/net/.git/rebase-apply/patch:35: space before tab in indent.
>   		return -1;
> /home/davem/src/GIT/net/.git/rebase-apply/patch:37: space before tab in indent.
>   	memset(&ifr, 0, sizeof(ifr));
> warning: squelched 29 whitespace errors
> warning: 34 lines add whitespace errors.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

My bad, will send v2.

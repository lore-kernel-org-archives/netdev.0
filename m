From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory Controller
Date: Tue, 27 Sep 2011 15:36:04 +0530
Message-ID: <CAKTCnz=DFUc=s9LzxPp-P2jOPXvNzWj8OswadCR09nVmM=ozxQ@mail.gmail.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-2-git-send-email-glommer@parallels.com>
	<4E794AA2.9080008@parallels.com>
	<CAKTCnzmkuL+9ftD5d0Z8b5w+DUSUoLiWqSX_TgGxtRxtoPsxpA@mail.gmail.com>
	<4E7DECA0.5020707@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com,
	kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net,
	gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org,
	kirill@shutemov.name, Ying Han <yinghan@google.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4E7DECA0.5020707@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

>> I know we have a lot of pending xxx_from_cont() and struct cgroup
>> *cont, can we move it to memcg notation to be more consistent with our
>> usage. There is a patch to convert old usage
>>
>
> Hello Balbir, I missed this comment. What exactly do you propose in this
> patch, since I have to assume that the patch you talk about is not applied?
> Is it just a change to the parameter name that you propose?
>

Yes, it is a patch posted on linux-mm by raghavendra

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

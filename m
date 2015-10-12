From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: Use-after-free in ep_remove_wait_queue
Date: Mon, 12 Oct 2015 14:17:37 +0200
Message-ID: <CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
 <20151012120249.GB16370@unicorn.suse.cz> <1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	dhowells@redhat.com, paul@paul-moore.com, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com, netdev@vger.kernel.org,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>,
	Jason Baron <jbaron@akamai.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>
To: syzkaller@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 2:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-10-12 at 14:02 +0200, Michal Kubecek wrote:
>
>> Probably the issue discussed in
>>
>>   http://thread.gmane.org/gmane.linux.kernel/2057497/
>>
>> and previous related threads.
>>
>
> Same issue, but Dmitry apparently did not trust me.

Just wanted to make sure. Let's consider this as fixed.

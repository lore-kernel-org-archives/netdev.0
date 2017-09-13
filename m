From: Cole Robinson <crobinso@redhat.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Wed, 13 Sep 2017 18:49:35 -0400
Message-ID: <813386f2-81ba-db8c-e86d-f36cd1b89537@redhat.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
 <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
 <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
 <370b38d5-346c-91df-4ad4-79886ae3a9ba@redhat.com>
 <a4807126-1f17-20bd-dace-d9c6b6c4787b@redhat.com>
 <E068C58A-DC80-4D98-ADE6-8F05304EC7ED@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>, Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E068C58A-DC80-4D98-ADE6-8F05304EC7ED@fb.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/13/2017 03:44 PM, Josef Bacik wrote:
> Alright thanks, this should fix it.
> 

Still no luck with all three patches applied to fedora 4.12.8-300 RPM. Pretty
sure I didn't mess up the testing but since I rarely do kernel builds it's not
impossible...

Thanks,
Cole

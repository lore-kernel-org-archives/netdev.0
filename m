From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: Re: [PATCH][v3.19.y] tun: return proper error code from tun_do_read
Date: Tue, 28 Apr 2015 17:18:51 -0400
Message-ID: <553FF93B.9080905@canonical.com>
References: <553FED33.8020406@canonical.com> <CA+5PVA78+XBL+zDdTtVa6FqM_ectVY0rrdYD=S+yU3CXVCFXPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>, agartrell@fb.com,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, jasowang@redhat.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben@decadent.org.uk>, xii@google.com,
	vyasevich@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+5PVA78+XBL+zDdTtVa6FqM_ectVY0rrdYD=S+yU3CXVCFXPg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/28/2015 05:15 PM, Josh Boyer wrote:
> On Tue, Apr 28, 2015 at 4:27 PM, Joseph Salisbury
> <joseph.salisbury@canonical.com> wrote:
>> Hello,
>>
>> Please consider including mainline commit
>> 957f094f221f81e457133b1f4c4d95ffa49ff731 in the next v3.19.y release.
>> It was included in the mainline tree as of v4.0-rc1.  It has been tested
>> and confirmed to resolve:
>> http://bugs.launchpad.net/bugs/1448942
>> And upstream bug report:
>> https://bugzilla.kernel.org/show_bug.cgi?id=90901
>>
>> The bug was introduce in v3.19-rc1 by commit 9b067034d0, so it is not
>> needed in any other stable kernels.
>>
>>
>>
>> commit 957f094f221f81e457133b1f4c4d95ffa49ff731
>> Author: Alex Gartrell <agartrell@fb.com>
>> Date:   Thu Dec 25 23:22:49 2014 -0800
>>
>>     tun: return proper error code from tun_do_read
> It's already queued for 3.19.6.  I pinged DaveM about it back in March
> and it eventually got queued up.
>
> josh
Great.  Thanks for the feedback, Josh.

Joe

From: Kir Kolyshkin <kir@openvz.org>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 19:09:28 +0400
Message-ID: <44FEE4A8.5060007@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<44FD7CF0.4030009@fr.ibm.com>	<m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>	<20060905165328.GA17317@MAIL.13thfloor.at>	<m17j0i1853.fsf@ebiederm.dsl.xmission.com> <44FEE0C2.6020205@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	sam@vilain.net, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:29508 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1751335AbWIFPKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:10:23 -0400
To: devel@openvz.org
In-Reply-To: <44FEE0C2.6020205@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev wrote:
> I think classifying network virtualization by Layer X is not good enough.
> OpenVZ has Layer 3 (venet) and Layer 2 (veth) implementations, but
> in both cases networking stack inside VE remains fully virtualized.
>   
Let's describe all those (three?) approaches at 
http://wiki.openvz.org/Containers/Networking
Everyone is able to read and contribute to that, and (I hope) we will 
come to the common understanding. I have started the article, please 
enlarge.

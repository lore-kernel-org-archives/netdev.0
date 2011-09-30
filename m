From: Alex Bligh <alex@alex.org.uk>
Subject: Re: [PATCH] Fix repeatable Oops on container destroy with conntrack
Date: Fri, 30 Sep 2011 16:54:21 +0100
Message-ID: <EBB118BCDCB0BE733EF43F1E@Ximines.local>
References: <2184C0CE5A5EDC94CDDA5053@Ximines.local>
 <20110912072524.GA2996@p183.telecom.by> <20110912093749.GE2194@1984>
 <E0902A9541FD5D118EA02B31@Ximines.local> <20110912183357.GC3641@1984>
 <87A32B21CA99D62CE1AB7A4B@Ximines.local>
 <7631498AC7E7C0EAD641AC7D@nimrod.local> <20110914013500.GB17051@1984>
 <A51A04647674405AF6C39A4F@nimrod.local> <20110928210851.GA2761@1984>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110928210851.GA2761@1984>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--On 28 September 2011 23:08:51 +0200 Pablo Neira Ayuso 
<pablo@netfilter.org> wrote:

>> As you can probably tell, my interest here is to get something that
>> doesn't oops into stable kernels.
>
> As said, I'm not sure that this can happen, given that the amount of
> patches that we need to fix it fine, sorry.

This is why I was suggesting the 2 line "don't oops" patch in the
interim.

-- 
Alex Bligh

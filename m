From: Baruch Even <baruch@ev-en.org>
Subject: Re: [RFC INTRO 0/5] H-TCP congestion control
Date: Fri, 22 Apr 2005 12:58:04 +0100
Message-ID: <4268E6CC.6060703@ev-en.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org> <20050311094239.4c59c29d@dxpl.pdx.osdl.net> <426849C2.7000409@ev-en.org> <20050422031510.GA13508@mail.shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"David S.Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, Douglas Leith <doug.leith@nuim.ie>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamie Lokier <jamie@shareable.org>
In-Reply-To: <20050422031510.GA13508@mail.shareable.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamie Lokier wrote:
> Baruch Even wrote:
> 
>>>>This patch is covered by a pending patent, a license is being worked on to
>>>>enable the inclusion in Linux. Comments and suggestions on this are also
>>>>solicited.
>>>
>>>
>>>Has this changed?
>>
>>This has changed now. The code is now released under the GNU GPL v2, 
>>according to what I was told this effectively implies that any patent 
>>right that the university will have regarding this technology is 
>>effectively licensed for use with this code.
>>
>>Please let me know if there is anything else that we need to do to let 
>>the review and possible inclusion of our contribution to proceed.
> 
> 
> The patents must be licensed for _all_ GPL v2 implementations of that
> algorithm, not just in this specific code.  (And it would be
> friendlier if you granted a patent license for GPL v2 and later).
> 
> That's because it's necessary for derivative works to have the patent
> license too, and derivative works includes taking the code and totally
> rewriting it for a different operating system or a different
> application.
 >
 > [snipped]

We are trying to get this sorted in the proper way, even as authors the 
issue here is also of dealing with the university bureaucracy so we'd 
prefer to avoid that and the associated paperwork as much as possible.

Is more paperwork/licenses really necessary?

What is it that we need to provide for this contribution to be 
acceptable for the kernel? Specifics please.

David, Can you comment on this and say if what was provided so far is 
sufficient to be accepted and if not what is needed?

Thanks,
Baruch

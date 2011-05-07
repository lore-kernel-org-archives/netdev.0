From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 6/7] net: Allow setting the network namespace by fd
Date: Sun, 08 May 2011 00:46:09 +0200
Message-ID: <4DC5CBB1.8080103@free.fr>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org> <1304735101-1824-1-git-send-email-ebiederm@xmission.com> <1304735101-1824-6-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304735101-1824-6-git-send-email-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2011 04:25 AM, Eric W. Biederman wrote:
> Take advantage of the new abstraction and allow network devices
> to be placed in any network namespace that we have a fd to talk
> about.
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
> ---
Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
